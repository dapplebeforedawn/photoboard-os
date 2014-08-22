# Photoboard-OS

A simple photo site.  Don't trust your photos to ad revenue.

## Setup

Environment variables you need to set
```
ENV['AWS_SECRET']
ENV['AWS_KEY']
```

Bucket configuration:
```
# config/uploaders.yaml
development:
  storage: fog
  bucket: "photoboard-devel"
production:
  storage: fog
  bucket: "photoboard-prod"
test:
  storage: file
```

## Theory of Operation

1. Deploy the app.
2. The background worker watches a `/raw` folder in your bucket.
3. When new files are detected they are oriented, and thumbnails are made.
4. Pictures show up on the site!
5. Duplicate (by MD5) photos are ignored.

## Features

1. Click the pencil on the right hand side to add a comment.
2. Click the spot on the photo you'd write on if it were a polaroid to add a title.
3. Comments and titles are auto saved.
4. Embiggen with the little magnifying glass
5. Checkbox in the upper right marks a photo for delete (it will turn red).  Delete was not actually implemented, this is just a flag in the database.
6. Infinite scroll done the right way.
