HTTP Queries
============

> When using restclient-mode, simply C-c c-c to run the query

# Check elk cluster
GET http://localhost:9242

# status
GET http://localhost:9242/_cluster/health?pretty

# dump documents
GET http://localhost:9242/fri.0/_search

# search doc
POST http://localhost:9242/fri.0/_search
Content-Type: application/json

{
  "query": { "query_string": { "query": "haskell" } }
}
