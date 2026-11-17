output "vpc_id" {
  description = "Identificador de la VPC"
  value       = aws_vpc.principal.id
}

output "subred_publica_ids" {
  description = "Identificadores de las subredes públicas"
  value       = aws_subnet.publica[*].id
}
