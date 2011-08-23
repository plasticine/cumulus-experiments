for i in {1..10000}; do
  curl -X POST -H "Content-Type: application/json" -d "{\"type\": \"page_view\", \"response_time\": $i, \"resource\":\"index\"}" http://localhost:4000/facts
  echo $i
done
