
# docker CLI
ng:
	docker build ./nginx -t nginx_app
run:
	docker run --name nginx -p 8001:80 -d 234660340542.dkr.ecr.ap-northeast-1.amazonaws.com/nginx

# curl
http:
	curl -I command-style.com
https:
	curl -I https://command-style.com


# ECS CLI
ecs_list:
	aws ecs list-clusters
ecs_debug:
	aws ecs list-tasks --cluster ECS-Cluster --desired-status STOPPED
ecs_task:
	aws ecs describe-tasks --cluster ECS-Cluster --tasks bcae2564178f4fcaab09f206d3fe9e70


# ECR CLI
list:
	aws ecr describe-repositories
login:
	aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin 234660340542.dkr.ecr.ap-northeast-1.amazonaws.com

create:
	docker context create ecs myecs
aws_context:
	docker context use myecs
default_context:
	docker context use default
context_list:
	docker context ls

# front
repo_front:
	aws ecr create-repository --repository-name next_app
build_front:
	docker build -t next_app ../app
tag_front:
	docker tag app-nextjs 234660340542.dkr.ecr.ap-northeast-1.amazonaws.com/next_app:latest
push_front:
	docker push 234660340542.dkr.ecr.ap-northeast-1.amazonaws.com/next_app:latest

# middle
repo_ng:
	aws ecr create-repository --repository-name nginx
build_ng:
	docker build -t nginx ./nginx
tag_ng:
	docker tag nginx 234660340542.dkr.ecr.ap-northeast-1.amazonaws.com/nginx:latest
push_ng:
	docker push 234660340542.dkr.ecr.ap-northeast-1.amazonaws.com/nginx:latest

# api
repo_api:
	aws ecr create-repository --repository-name go_api
build_api:
	docker build -t go_api ../server
tag_api:
	docker tag go_api:latest 234660340542.dkr.ecr.ap-northeast-1.amazonaws.com/go_api:latest
push_api:
	docker push 234660340542.dkr.ecr.ap-northeast-1.amazonaws.com/go_api:latest

