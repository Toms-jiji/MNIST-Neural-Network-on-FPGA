import serial
import numpy as np
from PIL import Image, ImageDraw
import tkinter as tk
 
# Global variable to store the last mouse position
last_pos = None
 
# Function to capture drawing from the screen and convert it to 28x28 grayscale image
def capture_drawing():
    # Convert the drawing to a PIL image
    image = Image.new('L', (280, 280), 'black')  # Change the canvas to black
    draw = ImageDraw.Draw(image)
    for line in lines:
        draw.line(line, fill='white', width=10)  # Change the drawing color to white
 
    # Resize to 28x28
    image = image.resize((28, 28))
 
    # Convert to NumPy array
    drawing = np.array(image)
 
    return drawing
 
# Function to send drawing data
def send_drawing():
    # Capture drawing
    drawing = capture_drawing()
 
    # Preprocess data
    drawing = drawing.reshape((28 * 28))
    drawing = drawing.astype('float32') / 255
 
    # Open serial port
    # ser = serial.Serial('COM14', 9600)
 
    # Open text file
    with open('serial3.txt', 'w') as f:
        # Send drawing data
        for pixel in drawing:
            # Convert pixel value to 8-bit integer
            pixel_8bit = int(pixel * 255) & 0xFF
 
            # Create 16-bit value with original pixel value in MSB and zeros in LSB
            pixel_16bit = (pixel_8bit << 8) & 0xFFFF
 
            # Print the 16-bit value in binary format
            print(f"Pixel: {pixel_16bit:016b}")
 
            # Write the 16-bit value to the text file
            f.write(f"{pixel_16bit:016b}\n")
 
            # Split into two bytes
            lsb = (pixel_16bit >> 8) & 0xFF
            msb = pixel_16bit & 0xFF
 
            # Send the two bytes
            # ser.write(bytes([msb]))
            # ser.write(bytes([lsb]))
 
    # Close serial port
    # ser.close()
 
# Function to draw on canvas
def draw(event):
    global last_pos
    x, y = event.x, event.y
    if last_pos is not None:
        # Draw line from last position to current position
        canvas.create_line(last_pos[0], last_pos[1], x, y, fill='white', width=50)
        lines.append([last_pos[0], last_pos[1], x, y])
    last_pos = (x, y)  # Update last position
 
# Function to reset the canvas
def reset_canvas():
    global last_pos
    canvas.delete('all')
    lines.clear()
    last_pos = None  # Reset last position
 
# Create Tkinter window
window = tk.Tk()
window.title('Draw')
 
# Create canvas
canvas = tk.Canvas(window, width=280, height=280, bg='black')  # Change the canvas to black
canvas.pack()
 
# Create send button
button_send = tk.Button(window, text='Send', command=send_drawing)
button_send.pack()
 
# Create reset button
button_reset = tk.Button(window, text='Reset', command=reset_canvas)
button_reset.pack()
 
# List to store lines
lines = []
 
# Bind mouse events to canvas
canvas.bind('<B1-Motion>', draw)
 
# Start Tkinter event loop
window.mainloop()