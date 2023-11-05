resource "aws_db_subnet_group" "production" {
  name       = "main"
  subnet_ids = [aws_subnet.subnet.id, aws_subnet.subnet2.id]
}

resource "aws_db_instance" "production" {
  identifier              = "production"
  db_name                 = var.rds_db_name
  username                = var.rds_username
  password                = var.rds_password
  port                    = "5432"
  engine                  = "postgres"
  engine_version          = "5.7"
  instance_class          = var.rds_instance_class
  allocated_storage       = "20"
  storage_encrypted       = false
  vpc_security_group_ids  = [aws_security_group.rds.id]
  db_subnet_group_name    = aws_db_subnet_group.production.name
  multi_az                = false
  storage_type            = "gp2"
  publicly_accessible     = false
  backup_retention_period = 7
  skip_final_snapshot     = true
}

resource "null_resource" "db_setup" {
  provisioner "local-exec" {

    command = "psql -h ${var.rds_db_name} -p 5432 -U \"${var.rds_username}\" -d ${var.rds_db_name} -f \"db-init.sql\""

    environment = {
      PGPASSWORD = "${var.rds_password}"
    }
  }
}
