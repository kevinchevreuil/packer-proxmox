# déclaration des variables
variable "cloudinit_storage_pool" {
  type    = string
}

variable "cores" {
  type    = string
}

variable "disk_format" {
  type    = string
}

variable "disk_size" {
  type    = string
}

variable "disk_storage_pool" {
  type    = string
}

variable "disk_storage_pool_type" {
  type    = string
}

variable "cpu_type" {
  type = string
}

variable "memory" {
  type    = string
}

variable "proxmox_api_password" {
  type      = string
  sensitive = true
}

variable "proxmox_api_user" {
  type = string
}

variable "proxmox_host" {
  type = string
}

variable "proxmox_node" {
  type = string
}

# création de notre ressource debia-11 (taille disque, nom template, le vm_id a utilisé etc..)
source "proxmox-iso" "debian-11" {
  proxmox_url              = "https://${var.proxmox_host}/api2/json"
  insecure_skip_tls_verify = true
  username                 = var.proxmox_api_user
  password                 = var.proxmox_api_password
  ssh_timeout              = "30m"

  template_description = "Debian 11 cloud-init template"
  node                 = var.proxmox_node
  vm_id = 9999
  network_adapters {
    bridge   = "vmbr1"
    firewall = false
    model    = "e1000"
  }
  disks {
    disk_size         = var.disk_size
    format            = var.disk_format
    io_thread         = true
    storage_pool      = var.disk_storage_pool
    storage_pool_type = var.disk_storage_pool_type
    type              = "scsi"
  }
  scsi_controller = "virtio-scsi-single"

  iso_file       = "exo-industries-cephfs:iso/debian-11.7.0-amd64-netinst.iso"
  http_directory = "./"
  boot_wait      = "10s"
# la boot command par défaut sur debian d'apres la doc pour l'autoinstallation par preseed
  boot_command   = ["<esc><wait>auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian-preseed.cfg<enter>"]
  unmount_iso    = true

  cloud_init              = true
  cloud_init_storage_pool = var.cloudinit_storage_pool

  vm_name  = "debian-template"
  cpu_type = var.cpu_type
  os       = "l26"
  memory   = var.memory
  cores    = var.cores
  sockets  = "1"
# l'user ssh (rien de sorcier ici)
  ssh_password = "projet"
  ssh_username = "projet"
}

build {
  sources = ["source.proxmox-iso.debian-11"]

  provisioner "file" {
    destination = "/tmp/cloud.cfg"
    source      = "cloud.cfg"
  }
  provisioner "shell" {
    inline = [
      "echo 'projet' | sudo -S mv /tmp/cloud.cfg /etc/cloud/cloud.cfg",
      "echo 'projet' | sudo -S apt-get install -y ssh python3 console-data && sudo loadkeys fr",
      "echo 'projet' | sudo -S systemctl enable ssh",
      "echo 'projet' | sudo -S sed -i 's/# kbd/configure_kbd: {layout: fr}/' /etc/cloud/cloud.cfg",
      "echo 'projet' | sudo -S service keyboard-setup restart",
      "echo 'projet' | sudo -S localectl set-keymap fr",
      "echo 'projet' | sudo -S mkdir -p /home/projet/.ssh",
      "echo 'projet' | sudo -S touch /tmp/authorized_keys",
      "echo 'projet' | sudo -S chown -R projet:projet /home/projet/.ssh",
      "echo 'projet' | sudo -S chmod 777 /home/projet/.ssh",
      "echo 'projet' | sudo -S mv /tmp/authorized_keys /home/projet/.ssh/authorized_keys",
      "echo 'projet' | sudo -S chmod 666 /home/projet/.ssh/authorized_keys",
      "echo 'projet' | sudo -S echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMHxS3L3MSzmCcmq+wx0PU6EjhadgoiKrjt0Uz2BHlP1 mjc@MiaouBookM1.local' >> /home/projet/.ssh/authorized_keys",
      "echo 'projet' | sudo -S echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAJ4+tH8JJDK2a6zMJ/eaQJoHVeZ+RGFn9IYtVEeUSbjDWZV0JTYeyeyz/YccvyFQ/2poRHsLzejebh0fpw8wE1VpwgPteBr7Frnv9Yx5lKVvwZhk91beiOAAIfMTex3aoVhqSbS3QQB08MUysPNmGveIJkdiIECtel+/nLR/1xLVe7lA51SqQtI2EfnigA+gedgEN5s4xpnRkxG/OtJkFlprIFKXrVDjUBvqVNVPSqyv6Di5q5ezmSfltmDlpYEK5iSf+HJ5aM1vn+BsEEmFrn3tfzZEdOvx+XRPMMNG4wU6m2pkGvSEydX15wAlAeDDlOFJ37E4II06SaVivK9259Gqc2cCfu13uVUZWAfRtP/Wegls4f3NtVmQgO4nIbqNFBwFclwQXcP3rUgRqp/PlO+eg9LcQkS3u2WTWDbBOfByUeBC6kAok07Jb4zhfL67ANKUaNWNsWZoS3P2MFlsN/NQ7HTNe97jRsUj0E1n5/0wy3G3/PsPvorZd4WNoJGyBQIvdKRvBv4r93Dyh/VtIBGOdMmkRzw4qwVlM+8OGbb/d2Xhz53K2+CkaaYXvTETwfbiz8q3QXoeGyRaKLB3ZRHClm/ua1txmgMVekA2D2nRLWzxfaLch7qpJJY8yMSn2CRxafkNeOEz1yIf2LuQIrqoXrxDroku7rIdFxAaPzw== vedom1\\oualid.lehegarat@L-5CG1215H6G' >> /home/projet/.ssh/authorized_keys",
      "echo 'projet' | sudo -S echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCZW++oZREcFnZ6fSR3y9i0xuEfHcZBUZiw/A4/fTiVYeI13hCDbAHyg0C52el5DIaEPoPUhkfXl6mlj0Pgb9xLkd6iBIsLgftcMJXaGV80+IY+PU1nnxajab1W2gUlhIodtGwlOPksAUfBqfWP9JXN2M1W8lm43jz9IJu/DRheylGteZ6ANKE5xplS7N5iNJ87etm8MpkF+m90y4phpqviFBJZvpcuqOSAG8yQWosTaB7tHCkKGPVwzqbwyjHXNTvK7lz5TjfR6E4iplBrWc3iclnOGuTivZhSPI8dlFN/mQRjfDYKAolv05JMxsD0nnWeUKUMYZaRkAHC+vUjVCmb rsa-key-20221125' >> /home/projet/.ssh/authorized_keys",
      "echo 'projet' | sudo -S echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDH34K1O0/lqheY7jIBHdJdN31avpDnIDkx1cRakDWfztT24KdQew6T97ZGcK3j6FYLvBSVOq5jUt7VYJ7j3L9hkMqYMvsxjqhWFnWcpXDVME2/3xO8EDzWmFZORTy8aI5Ou6YBIHyG2T4HOF4OWLqIkWqmTvjIoHSVTlQUUvugrgtuCgJCM4s7m1C6KtMBr7LjISg3Rza5zTvjE5z11lw/r83RfneHH5R5O7afFfhcHap2Oazuw3J/9Yvjs84JHTaQCvn+0EVXavYRhP0h20mllatkoAbAkQPOor4tVXb2lVgp3cSOrb/dKLNQg707acfuHNCEUoHWnpFe1hFJ0AbwIWEXKkq56nH/D1FimMmYRNlF6QUrykU92/J9rKJpabar9PQAZU80PLdcV1lfVt+rCkwfl0S+agKATtlMg5U+waYynW19mwz9cWPu5yW3DIi2tP5Zwxd17iHbx+467CUbRpFtFrBhS+mgRxUVTohH6na79WHeAEQG+FcOT6KeZc32FVEmDHTr5vrzkFkeNseEIJYvGNdNeQe9QXhKZ2awAs/RPGfj7OfmFBzOny57k7WB1QgwfjpjEbu2HMCLcZEh2Fx3Uzw1G3skhwXOqDksI8Mnorcbaz3yKNcuFQkbQS+fUSZNAivBPcZGiZyjrl/bjGO96AkvwpQ2M3nGEp96VQ== kaisen@kaisenlinux-macbookpro' >> /home/projet/.ssh/authorized_keys",
      "echo 'projet' | sudo -S echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+Vc4tXV7eaxJLIYvQTMnR1W9KYA9S4qbJD/NBcu2mUEFl+hWI4PKdRxJ/zR13kC/wAl1oniOwLIOOOShkXSj+1w0dNhFUNIy0z3C/BH0/Qt8X/Yu55MEWiyihZmxLLcX9bEopA7Al5NXlZVZtobB08hNYsOiTyKK0dDauqLVg1EDZW+v7+Lt4Jfu0e1BX6STpoP/KH3SaM1KR4nUeW1FQn9yG0hnXulUVZsgGSWghWPr9tgQuD3WcKhwsoOm3J5bY0wvk2dPYznLvqcyI+8KQznRZcLT6GL+5PskZsHku56cdOtZcslVvKWYbC62H2HrcR5d/PLqaqmuc10eplIyprmdpmDNa+ml5s9MXeDWM+N5ShG/Ht0XTH8TVbpWjtxq7z1IbDm/eBaqFQpYAKA00a/KKRwQpeh6BXSpXi+Y1kAkOrHeDsYSzFmn6SeHSLS9Ampi/u/8yEdMhJYdefIdk2sFG+3JG0ocKi+8U8Iq1FiPTCxIKjfhvHApcGMsM5r3ej4P91uqFHHmlGuvjB7+ogBDeLpCxeikCdF4/wt5lfZMJlGpqatSEyfcIC8RYj1qgjv7UZE5xjB7EXtvc1eO69kCQjb3KUX3+YeJMllx8qSwbo5GVu6SiJ5oNxoWtTl6oO5H++WYFcHJhrtST2vT3Et+k6mLUFDVuKa31vNHMqQ== projet@kaisenlinux' >> /home/projet/.ssh/authorized_keys",
      "echo 'projet' | sudo -S sudo chown -R projet:projet /home/projet/.ssh",
      "echo 'projet' | sudo -S chmod 755 /home/projet/.ssh",
      "echo 'projet' | sudo -S chmod 644 /home/projet/.ssh/authorized_keys",
      "echo 'projet' | sudo -S apt update && sudo -S apt full-upgrade -y",
    ]
  }
}
