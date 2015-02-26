rp_module_id="splashenable"
rp_module_desc="Enable/disable Splashscreen"
rp_module_menus="3+"
rp_module_flags="nobin"

function set_enableSplashscreenAtStart()
{
    clear
    printHeading "Enabling custom splashscreen on boot."

    getDepends fbi

    chmod +x "$scriptdir/supplementary/asplashscreen/asplashscreen"
    cp "$scriptdir/supplementary/asplashscreen/asplashscreen" "/etc/init.d/"

    find $scriptdir/supplementary/splashscreens/retropieproject2014/ -type f > /etc/splashscreen.list

    # This command installs the init.d script so it automatically starts on boot
    update-rc.d asplashscreen defaults

    # not-so-elegant hack for later re-enabling the splashscreen
    update-rc.d asplashscreen enable

#     # ===========================================
#     # TODO Alternatively use plymouth. However, this does not work completely. So there is still some work to be done here ...
#     # instructions at https://github.com/notro/fbtft/wiki/FBTFT-shield-image#bootsplash
#     apt-get install -y plymouth-drm

#     echo "export FRAMEBUFFER=/dev/fb1" | tee /etc/initramfs-tools/conf.d/fb1

#     if [[ ! -f /boot/$(uname -r) ]]; then
#         update-initramfs -c -k $(uname -r)
#     else
#         update-initramfs -u -k $(uname -r)
#     fi
#     imgname=$(echo "update-initramfs: Generating /boot/initrd.img-3.12.20+" | sed "s|update-initramfs: Generating /boot/||g")
#     echo "initramfs=$imgname" >> /boot/config.txt

#     echo "splash quiet plymouth.ignore-serial-consoles $(cat /boot/cmdline.txt)" > tempcmdline.txt
#     cp /boot/cmdline.txt /boot/cmdline.txt.bak
#     mv tempcmdline.txt /boot/cmdline.txt

#     mkdir -p "/usr/share/plymouth/themes/retropie"
#     cat > "/usr/share/plymouth/themes/retropie/retropie.plymouth" << _EOF_
# [Plymouth Theme]
# Name=RetroPie Theme
# Description=RetroPie Theme
# ModuleName=script

# [script]
# ImageDir=/usr/share/plymouth/themes/retropie
# ScriptFile=/usr/share/plymouth/themes/retropie/retropie.script
# _EOF_

#     cat > "/usr/share/plymouth/themes/retropie/retropie.script" << _EOF_
# # only PNG is supported
# pi_image = Image("splashscreen.png");

# screen_ratio = Window.GetHeight() / Window.GetWidth();
# pi_image_ratio = pi_image.GetHeight() / pi_image.GetWidth();

# if (screen_ratio > pi_image_ratio)
#   {  # Screen ratio is taller than image ratio, we will match the screen width
#      scale_factor =  Window.GetWidth() / pi_image.GetWidth();
#   }
# else
#   {  # Screen ratio is wider than image ratio, we will match the screen height
#      scale_factor =  Window.GetHeight() / pi_image.GetHeight();
#   }

# scaled_pi_image = pi_image.Scale(pi_image.GetWidth()  * scale_factor, pi_image.GetHeight() * scale_factor);
# pi_sprite = Sprite(scaled_pi_image);

# # Place in the centre
# pi_sprite.SetX(Window.GetWidth()  / 2 - scaled_pi_image.GetWidth () / 2);
# pi_sprite.SetY(Window.GetHeight() / 2 - scaled_pi_image.GetHeight() / 2);
# _EOF_

#     plymouth-set-default-theme -R retropie
#     # =============================
}

function set_disableSplashscreenAtStart()
{
    clear
    printHeading "Disabling custom splashscreen on boot."

    update-rc.d asplashscreen disable

    # # TODO plymouth command. Not used yet ...
    # sed -i 's|splash quiet plymouth.ignore-serial-consoles ||g' /boot/cmdline.txt
}

function configure_splashenable() {
    cmd=(dialog --backtitle "$__backtitle" --menu "Choose the desired boot behaviour." 22 86 16)
    options=(1 "Disable custom splashscreen on boot."
             2 "Enable custom splashscreen on boot")
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choices" ]]; then
        case $choices in
            1) set_disableSplashscreenAtStart
               printMsgs "dialog" "Disabled custom splashscreen on boot."
                            ;;
            2) set_enableSplashscreenAtStart
               printMsgs "dialog" "Enabled custom splashscreen on boot."
                            ;;
        esac
    fi
}
