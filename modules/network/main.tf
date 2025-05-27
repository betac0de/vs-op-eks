resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name                                            = "${var.project_name}-vpc"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared" # Required for EKS Load Balancers & PVs
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# --- Public Subnets ---
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index % length(var.availability_zones)] # Cycle through AZs
  map_public_ip_on_launch = true                                                                 # Instances in public subnets get public IPs

  tags = {
    Name                                            = "${var.project_name}-public-subnet-${count.index + 1}"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared" # Required for EKS public Load Balancers
    "kubernetes.io/role/elb"                        = "1"      # For classic ELBs, if ever used
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# --- Private Subnets & NAT Gateway ---
# One NAT Gateway per AZ for HA is recommended for production.
# This example creates one NAT Gateway in the first public subnet for simplicity and cost.
# For multiple NAT Gateways, you would loop this resource.

resource "aws_eip" "nat" {
  # count = length(var.private_subnet_cidrs) > 0 ? 1 : 0 # Create EIP only if private subnets exist
  # For multiple NATs: count = length(aws_subnet.public)
  # domain = "vpc" # for vpc scope eip
  tags = {
    Name = "${var.project_name}-nat-eip-1"
  }
  depends_on = [aws_internet_gateway.gw] # Ensure IGW is created before EIP for NAT
}

resource "aws_nat_gateway" "nat" {
  # count = length(var.private_subnet_cidrs) > 0 ? 1 : 0
  # For multiple NATs: count = length(aws_subnet.public)
  allocation_id = aws_eip.nat.id          # For single NAT: aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id # Place NAT in the first public subnet
  # For multiple NATs: aws_subnet.public[count.index].id

  tags = {
    Name = "${var.project_name}-nat-gw-1"
  }

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index % length(var.availability_zones)] # Cycle through AZs
  map_public_ip_on_launch = false

  tags = {
    Name                                            = "${var.project_name}-private-subnet-${count.index + 1}"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared" # Required for EKS internal Load Balancers
    "kubernetes.io/role/internal-elb"               = "1"      # For EKS internal Load Balancers
  }
}

resource "aws_route_table" "private" {
  # count = length(var.private_subnet_cidrs) > 0 ? 1 : 0 # Create only if private subnets exist
  # For multiple NATs / Route tables per AZ:
  # count = length(aws_subnet.private)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id # For single NAT: aws_nat_gateway.nat[0].id
    # For multiple NATs: aws_nat_gateway.nat[count.index].id (if one NAT per AZ)
    # Or a more complex lookup if NATs are not 1:1 with private subnets/AZs
  }

  tags = {
    Name = "${var.project_name}-private-rt-1"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id # For single private RT: aws_route_table.private[0].id
  # For multiple private RTs: aws_route_table.private[count.index].id (if one RT per private subnet/AZ)
}