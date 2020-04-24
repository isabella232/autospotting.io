all: build upload

build:
	hugo -DEF

upload:
	aws s3 sync public/ s3://autospotting.org/
	aws cloudfront create-invalidation --distribution-id E18SR0Y6B0IZWS --paths '/*'

local:
	open http://localhost:1313/
	hugo server -DEF
