#declaring function
install_dependancies() {

    ( #running set -euo pipefall in a subshell so that it doesn't affect any code but this function
          #set -euo pipefail:

            # set -e = exit the second theres an error
            # set -u = treat all unset variables as errors
            # set -o pipefail = if any command in the pipeline fails then the entire script fails

        #this helps for when you need a script to die loudly, so that you can debug the errors
        set -euo pipefail

        #this line sets a local variable which means that its setting a variable that can only be used by the function, this cannot be used outside of the function
        #the variable its setting is deps = all-arguments, which means if you ran this function as "install_dependancies hi my name is snapple", the variable would be "deps = (hi, my, name, is, snapple) and it would take every argument as a seperate object in the list"
        local deps=($@)
        local missing=()
        #this code just takes every package that you put as the argument and checks if they are already installed
        #its to make sure you don't try to reinstall the packages you already have, because that would waste time and it would be unnecessary since this script is for installing dependancies
        #it also sets the "$missing" variable to the length of all of the missing packages
        for pkg in "${deps[@]}"; do
            if ! command -v "$pkg" &>/dev/null; then
                missing+=("$pkg")
            fi
        done
        #if every dependancy is there already then it exits the function and doesn't go through with the code below
        if [ ${#missing[@]} -eq 0 ]; then
            return
        fi
        #making distro var
        local DISTRO="unknown"
        #getting distro id (name) and turning it into said var
        if [ -f /etc/os-release ]; then
            #opens /etc/os-release as the source file
            . /etc/os-release
            #reads ID from /etc/os-release
            DISTRO="${ID,,}"
        fi
        echo "detected $DISTRO attempting to install missing dependencies: ${missing[*]}..."
        #this big ol wall of text is just bash taking the "DISTRO" variable and searching through "ubuntu|debian|linuxmint|ect" to find which os matches yours and then it corresponds that os to the package manager you have, so arch would be pacman, debian would be apt, fedora would be dnf, and so on
        #it uses "${missing[@]}" which expands to all of the names of the packages it deemed missing
        #it also uses either -y or --noconfirm or --auto or whatever the fuck to automatically download the package without confirmation from the user
        #the "*)" part at the end basically just stands for unrecognized, which prints the echo text in the right into the terminal
        case "$DISTRO" in
           #list of all distros                                                                                                                       list of install commands to go with them
            ubuntu|debian|linuxmint|pop|elementary|devuan|kali|zorin|peppermint|deepin|ubuntu‑studio|linuxlite|sparky|lubuntu|asahi|linuxkodachi)     sudo apt update && sudo apt install -y "${missing[@]}" ;;
            arch|cachyos|omarchy|endeavouros|artix|garuda|manjaro|anarchy|arcolinux|blackarch|steamos|hyperbola|archlabs|archcraft)                   sudo pacman -S --noconfirm "${missing[@]}" ;;
            fedora|amzn|oracle|cloudlinux|nobara|ultramarine|risios)                                                                                  sudo dnf install -y "${missing[@]}" ;;
            centos|rhel|rocky|almalinux|scientific|vzlinux|navylinux)                                                                                 sudo yum install -y "${missing[@]}" ;;
            opensuse|suse|sles|sle|libertylinux|opensuse-tumbleweed|opensuse-leap|geckolinux)                                                         sudo zypper install -y "${missing[@]}" ;;
            void)                                                                                                                                     sudo xbps-install -Sy "${missing[@]}" ;;
            nixos)                                                                                                                                    sudo nix-env -iA "${missing[@]}" ;;
            alpine)                                                                                                                                   sudo apk add "${missing[@]}" ;;
            gentoo|funtoo|calculate)                                                                                                                  sudo emerge --ask "${missing[@]}" ;;
            mageia|mandriva|openmandriva|rosa)                                                                                                        sudo urpmi --auto "${missing[@]}" ;;
            slackware|salix)                                                                                                                          slackpkg install "${missing[@]}" ;;
            solus)                                                                                                                                    sudo eopkg install "${missing[@]}" ;;
            guix)                                                                                                                                     sudo guix install "${missing[@]}" ;;
            crux)                                                                                                                                     sudo prt-get install "${missing[@]}" ;;
            antiX|mxlinux|lmde|raspbian|pureos|tails|q4os|bodhi|bunsenlabs)                                                                           sudo apt update && sudo apt install -y "${missing[@]}" ;;
            clearlinux)                                                                                                                               sudo swupd update && sudo swupd bundle-add "${missing[@]}" ;;
            kubuntu|xubuntu|ubuntu‑kylin)                                                                                                             sudo apt update && sudo apt install -y "${missing[@]}" ;;
            parrot)                                                                                                                                   sudo apt update && sudo apt install -y "${missing[@]}" ;;
            *)                                                                                                                                        echo "unsupported distro: $DISTRO u gotta install ${missing[*]} manually." ;;
        esac
    ) #these three just close the "case", "subshell" and exit the "function" so that the function is now ready to use
}
#this line calls the function with "install_dependancies", and runs all of the code above while using any and all arguments you run this script with "./install_dependancy arg1 arg2 arg3"
install_dependancies $@ #arg1 arg2 arg3
