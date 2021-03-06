#!/bin/sh

# specify full path to FIRMADYNE repository
MAIN_DIR=/home/niorehkids/firmanal

# specify full paths to other directories
BINARY_DIR=${MAIN_DIR}/bin
DB_DIR=${MAIN_DIR}/db
VM_DIR=${MAIN_DIR}/qemu/vm
VM_SCRIPT_DIR=${MAIN_DIR}/qemu/scripts
SCRIPT_DIR=${MAIN_DIR}/scripts
FIRMWARE_DIR=${MAIN_DIR}/images
RESULT_DIR=${MAIN_DIR}/results

# functions to safely compute other paths

check_arch () {
    ARCHS=("armel" "mipseb" "mipsel")

    if [ -z "${1}" ]; then
        return 0
    fi

    match=0
    for i in "${ARCHS[@]}"; do
        if [ "${1}" == "$i" ]; then
            match=1
        fi
    done

    if [ "${match}" -eq 0 ]; then
        return 0
    fi

    return 1
}

check_number () {
    if [ "${1}" -ge 0 ]; then
        return 1
    fi

    return 0
}

check_root () {
    if [ "${EUID}" -eq 0 ]; then
        return 1
    fi

    return 0
}

get_console () {
    if check_arch "${1}"; then
        echo "Error: Invalid architecture!"
        exit 1
    fi

    echo "${BINARY_DIR}/console.${1}"
}

get_fs () {
    if check_number "${1}"; then
        echo "Error: Invalid image number!"
        exit 1
    fi

    echo "`get_vm "${1}"`/image.raw"
}

get_fs_mount () {
    if check_number "${1}"; then
        echo "Error: Invalid image number!"
        exit 1
    fi

    echo "`get_vm "${1}"`/image/"
}

get_kernel () {
    if check_arch "${1}"; then
        echo "Error: Invalid architecture!"
        exit 1
    fi

    case "${1}" in
        armel)
            echo "${BINARY_DIR}/zImage.${1}"
            ;;
        mipseb)
            echo "${BINARY_DIR}/vmlinux.${1}"
            ;;
        mipsel)
            echo "${BINARY_DIR}/vmlinux.${1}"
            ;;
        *)
            echo "Error: Invalid architecture!"
            exit 1
    esac
}

get_nvram () {
    if check_arch "${1}"; then
        echo "Error: Invalid architecture!"
        exit 1
    fi

    echo "${BINARY_DIR}/libnvram.so.${1}"
}

get_qemu () {
    if check_arch "${1}"; then
        echo "Error: Invalid architecture!"
        exit 1
    fi

    case "${1}" in
        armel)
            echo "qemu-system-arm"
            ;;
        mipseb)
            echo "qemu-system-mips"
            ;;
        mipsel)
            echo "qemu-system-mipsel"
            ;;
        *)
            echo "Error: Invalid architecture!"
            exit 1
    esac
}

get_qemu_disk () {
    if check_arch "${1}"; then
        echo "Error: Invalid architecture!"
        exit 1
    fi

    case "${1}" in
        armel)
            echo "/dev/vda1"
            ;;
        mipseb)
            echo "/dev/sda1"
            ;;
        mipsel)
            echo "/dev/sda1"
            ;;
        *)
            echo "Error: Invalid architecture!"
            exit 1
    esac
}

get_qemu_machine () {
    if check_arch "${1}"; then
        echo "Error: Invalid architecture!"
        exit 1
    fi

    case "${1}" in
        armel)
            echo "virt"
            ;;
        mipseb)
            echo "malta"
            ;;
        mipsel)
            echo "malta"
            ;;
        *)
            echo "Error: Invalid architecture!"
            exit 1
    esac
}

get_vm () {
    if check_number "${1}"; then
        echo "Error: Invalid image number!"
        exit 1
    fi

    echo "${VM_DIR}/${IID}/"
}

get_device () {
    echo "/dev/mapper/loop0p1"
}
