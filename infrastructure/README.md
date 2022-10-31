# aws infrastructure with terraform

## 준비
### 설치 (Windows)
##### 1. Terraform
1. https://www.terraform.io/downloads 에서 windows용 설치
2. 내컴퓨터 속성 -> 고급 시스템 설정 -> 환경변수 path 편집 -> exe파일이 존재하는 경로 등록
3. cmd에서 `terraform -help` 명령어로 확인  

##### 2. AWS Cli
1. https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html 여기에서 설치
2. `aws --version` 으로 설치 확인  

#### 3. AWS account, credentials
1. 계정, 액세스 키 생성

### IntelliJ에서 사용준비
1. terraform 플러그인 설치
2. settings -> tools -> terraform 에서 terraform.exe 파일 경로 지정

## 테라폼 프로젝트 초기화  
- 0.10 버전 이상부터는 프로바이더가 플러그인으로 분리되었기 때문에 테라폼 프로젝트를 별도로 초기화해야 한다.
- infrastructure 디렉토리에서 `terraform init` 명령어를 수행한다.  
```
Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```  

설치가 완료되었다면 `terraform version` 명령어로 버전을 확인해보자. 이는 모든 프로바이더들의 버전까지 보여준다.
```
Terraform v1.3.3
on windows_386
+ provider registry.terraform.io/hashicorp/aws v4.37.0
```  

## 순서대로 리소스 생성
TODO: 작성