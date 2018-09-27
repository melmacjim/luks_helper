# What is this?

`encrpyted_volume_create.sh` may be used to quickly create a LUKS encrypted volume on a GUN/Linux block device (USB flash drive, HDD, or SSD).

`.encrpyted_volume_open_close_template.sh` is only a template script. IGNORE IT!<br>
`encrpyted_volume_create.sh` uses `encrpyted_volume_open_close_template.sh` to create an easy to use open and close LUKS script.<br>

The `encrpyted_volume_create.sh` script only asks the user for two inputs:<br>
1. If you want to use the last storage device connected to the comtputer you're on type "YES", otherwise you'll be asked to enter the device that you want to encrypt in the from "/dev/sdx".<br>
2. The name of the encrypted volume (examples: "red_usb", "1tb_hdd", "device03"; basically, just don't use spaces!).

Once the `encrpyted_volume_create.sh` script completes, the device specified will be encrypted via a LUKS AES 256 volume.<br>
Also, a script to easly open and close your new LUKS device will be on your Desktop (check `~/Desktop` or `$HOME/`) and the name of said script will begin with the name you gave for the encrypted volume.<br>


# How do I use this?

To execute the `encrpyted_volume_create.sh` script, open a terminal and cd into the `luks-scripts` directory and run:<br>
`sudo ./encrpyted_volume_create.sh`<br>
 or<br>
`sudo bash encrpyted_volume_create.sh`<br>


# How do I open and close the LUKS partition?

Once the `encrpyted_volume_create.sh` script completes and generates the `encrpyted_volume_open_close` script, you can use that script to open and close the LUKS partition as follows:<br>
`sudo ./encrpyted_volume_open_close.sh open`<br>
 and<br>
`sudo ./encrpyted_volume_open_close.sh close`<br>
