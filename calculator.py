import serial

ser = serial.Serial('/dev/ttyUSB0', 9600)  

try:
    while True:
        print("Ingrese el operando A: ")
        mensaje = int(input())
        ser.write(bytes([mensaje]))

        print("Ingrese el operando B: ")
        mensaje = int(input())
        ser.write(bytes([mensaje]))

        print("Ingrese el codigo de operacion: ")
        mensaje = int(input())
        ser.write(bytes([mensaje]))
        
        respuesta_bytes = ser.read(1)  # Lee un byte
        respuesta = int.from_bytes(respuesta_bytes, byteorder='big')  # Interpreta los bytes como un número binario
        print(f'Resultado: {respuesta:08b}')
except KeyboardInterrupt:
    pass

ser.close()

