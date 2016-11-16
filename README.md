# Atmega_upload
Bash Script to automate the code uploading to any atmega

# Requirements
avr-gcc and avrdude should be available in the system path

# Usage
sh atmega.sh [ -m|--mmcu  Microcontroller ] [ ( -w | --write ) || ( -r | --read )    path_to_file ]  

# Customising
The default uploader is 'usbasp'. you can change this to meet your requirements in line 103.
This script uses minimum requirements.
Feel free to add other arguments that are supported in avr-gcc or avrdude yourself or raise an issue

Any suggestions on improving this are welcome. 
