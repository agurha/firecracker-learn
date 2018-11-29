output "public_ip" {
  value = "${packet_device.vmonpacket.access_public_ipv4}"
}

output "where_to_ssh" {
  value = "${format("ssh root@%s", packet_device.vmonpacket.access_public_ipv4)}"
}