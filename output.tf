# output "public_ip" {
#   value = "${google_compute_instance.demo}"
# }

# output "where_to_ssh" {
#   value = "${format("ssh root@%s", google_compute_instance.demo.access_public_ipv4)}"
# }