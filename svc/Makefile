VERSION := latest

build:
	docker build --platform linux/amd64 -t dasmeta/mongo-backup-aws:$(VERSION) .

publish:
	docker push dasmeta/mongo-backup-aws:$(VERSION)

helm-install:
	cd helm/mongo-backup-aws && helm upgrade --install mongodb-backup-aws .
