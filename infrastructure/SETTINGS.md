# SETTINGS

### Region
- ap-northeast-2

### az suffix
- a
- c

### CIDR Rules
- VPC
  - 172.31.0.0/16
- Subnet
  - public
    - 172.31.(16 * suffix_num).0/20
  - private
    - 172.31.(16 * (suffix_num + (suffix_count * 1))).0 / 20
  - db private 
    - 172.31.(16 * (suffix_num + (suffix_count * 2))).0 / 20