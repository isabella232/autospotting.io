all: build upload

build:
	hugo -DEF

upload:
	aws s3 sync public/ s3://autospotting.org/
	aws cloudfront create-invalidation --distribution-id E18SR0Y6B0IZWS --paths '/*' &
	aws cloudfront create-invalidation --distribution-id EU2GBJ4P3Q96G --paths '/*' &

local:
	open http://localhost:1313/
	hugo server -DEF
