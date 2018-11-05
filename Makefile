all: build upload

build:
	hugo

upload:
	aws s3 sync public/ s3://autospotting.org/

local:
	chromium-browser http://localhost:1313/
	hugo server
