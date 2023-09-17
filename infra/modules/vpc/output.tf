output "vpc_id" {
    value = aws_vpc.main_vpc.id
  
}
output "public_subnet1_id" {
    value = aws_subnet.public_subnet[0].id
  
}
output "public_subnet2_id" {
    value = aws_subnet.public_subnet[1].id
  
}
output "public_subnet3_id" {
    value = aws_subnet.public_subnet[2].id
  
}
output "private_subnet4_id" {
    value = aws_subnet.private_subnet[0].id
  
}
output "private_subnet5_id" {
    value = aws_subnet.private_subnet[1].id
  
}
output "private_subnet6_id" {
    value = aws_subnet.private_subnet[2].id
  
}