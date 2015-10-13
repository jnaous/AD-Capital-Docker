#! /bin/bash
echo "Starting analytics agent for rest container..."; docker exec rest start-analytics ${EVENT_ENDPOINT}; echo "Done"
echo "Starting analytics agent for portal container..."; docker exec portal start-analytics ${EVENT_ENDPOINT}; echo "Done"
echo "Starting analytics agent for verification container..."; docker exec verification start-analytics ${EVENT_ENDPOINT}; echo "Done"
echo "Starting analytics agent for processor container..."; docker exec processor start-analytics ${EVENT_ENDPOINT}; echo "Done"
echo "Starting analytics agent for queuereader container..."; docker exec queuereader start-analytics ${EVENT_ENDPOINT}; echo "Done"

