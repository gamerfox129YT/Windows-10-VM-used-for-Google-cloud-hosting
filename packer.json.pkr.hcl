# This file was autogenerate by the BETA 'packer hcl2_upgrade' command. We
# recommend double checking that everything is correct before going forward. We
# also recommend treating this file as disposable. The HCL2 blocks in this
# file can be moved to other files. For example, the variable blocks could be
# moved to their own 'variables.pkr.hcl' file, etc. Those files need to be
# suffixed with '.pkr.hcl' to be visible to Packer. To use multiple files at
# once they also need to be in the same folder. 'packer inspect folder/'
# will describe to you what is in that folder.

# All generated input variables will be of string type as this how Packer JSON
# views them; you can later on change their type. Read the variables type
# constraints documentation
# https://www.packer.io/docs/from-1.5/variables#type-constraints for more info.

variable "iso-url" {
  type    = string
  default = "https://software-download.microsoft.com/download/pr/19041.264.200511-0456.vb_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:F1A4F2176259167CD2C8BF83F3F5A4039753B6CC28C35AC624DA95A36E9620FC"
}

variable "switch_name" {
  type    = string
  default = "Default Switch"
}

variable "win_username" {
  type    = string
  default = "vagrant"
}

variable "win_password" {
  type    = string
  default = "vagrant"
}

variable "disk_size" {
  type    = number
  default = 61440
}

variable "memory" {
  type    = number
  default = 2048
}

variable "cpus" {
  type    = number
  default = 2
}



# "timestamp" template function replacement
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors onto a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/from-1.5/blocks/source
source "hyperv-iso" "hyperv" {
  communicator     = "winrm"
  disk_size        = "${var.disk_size}"
  memory           = "${var.memory}"
  cpus             = "${var.cpus}"
  floppy_files     = ["Autounattend.xml", "update-windows.ps1", "configure-winrm.ps1"]
  generation       = "1"
  headless         = true
  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.iso-url}"
  shutdown_command = "shutdown /s /t 5 /f /d p:4:1 /c \"Packer Shutdown\""
  skip_compaction  = false
  switch_name      = "${var.switch_name}"
  winrm_password   = "${var.win_password}"
  winrm_timeout    = "10h"
  winrm_username   = "${var.win_username}"
}

#could not parse template for following block: "template: generated:15:42: executing \"generated\" at <.Name>: can't evaluate field Name in type struct { HTTPIP string; HTTPPort string }"

source "virtualbox-iso" "vbox" {
  communicator         = "winrm"
  disk_size            = "${var.disk_size}"
  floppy_files         = ["Autounattend.xml", "update-windows.ps1", "configure-winrm.ps1"]
  guest_additions_mode = "upload"
  guest_additions_path = "c:/Windows/Temp/windows.iso"
  guest_os_type        = "Windows10_64"
  hard_drive_interface = "sata"
  headless             = true
  iso_interface        = "sata"
  iso_checksum         = "${var.iso_checksum}"
  iso_url              = "${var.iso-url}"
  shutdown_command     = "shutdown /s /t 0 /f /d p:4:1 /c \"Packer Shutdown\""
  vboxmanage           = [["modifyvm", "{{.Name}}", "--memory", "${var.memory}"], ["modifyvm", "{{.Name}}", "--cpus", "${var.cpus}"], ["modifyvm", "{{.Name}}", "--vram", "32"]]
  winrm_insecure       = true
  winrm_password       = "${var.win_password}"
  winrm_timeout        = "10h"
  winrm_username       = "${var.win_username}"
}

source "vmware-iso" "vmware" {
  communicator        = "winrm"
  disk_size           = "${var.disk_size}"
  memory           = "${var.memory}"
  cpus             = "${var.cpus}"
  floppy_files        = ["Autounattend.xml", "update-windows.ps1", "configure-winrm.ps1"]
  guest_os_type       = "windows9-64"
  headless            = true
  iso_checksum        = "${var.iso_checksum}"
  iso_url             = "${var.iso-url}"
  skip_compaction     = false
  shutdown_command    = "shutdown /s /t 5 /f /d p:4:1 /c \"Packer Shutdown\""
  tools_upload_flavor = "windows"
  tools_upload_path   = "c:/Windows/Temp/windows.iso"
  
  winrm_password = "${var.win_password}"
  winrm_timeout  = "10h"
  winrm_username = "${var.win_username}"
}

# a build block invokes sources and runs provisionning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/from-1.5/blocks/build
build {

  sources = ["source.hyperv-iso.hyperv", "source.virtualbox-iso.vbox", "source.vmware-iso.vmware"]

  provisioner "powershell" {
    scripts = ["install-guest-tools.ps1", "enable-rdp.ps1", "disable-hibernate.ps1", "disable-autologin.ps1", "enable-uac.ps1", "no-expiration.ps1"]
  }
  provisioner "windows-restart" {}

  #could not parse template for following block: "template: generated:3:28: executing \"generated\" at <.Provider>: can't evaluate field Provider in type struct { HTTPIP string; HTTPPort string }"
  post-processor "vagrant" {
    keep_input_artifact  = false
    output               = "{{.Provider}}_windows-10.box"
    vagrantfile_template = "vagrantfile.template"
  }
}