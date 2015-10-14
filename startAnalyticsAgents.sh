#! /bin/bash
echo "Starting analytics agent for rest container..."; docker exec rest start-analytics; echo "Done"
echo "Starting analytics agent for portal container..."; docker exec portal start-analytics; echo "Done"
echo "Starting analytics agent for verification container..."; docker exec verification start-analytics; echo "Done"
echo "Starting analytics agent for processor container..."; docker exec processor start-analytics; echo "Done"
echo "Starting analytics agent for queuereader container..."; docker exec queuereader start-analytics; echo "Done"

