package main

import (
	"github.com/segmentio/kafka-go"
	"os"
	"strconv"
)

func main() {
	topicName := os.Getenv("TOPIC_NAME")
	if topicName == "" {
		panic("topic name not found")
	}

	eventNumber, err := strconv.Atoi(os.Getenv("EVENTS_NUM"))
	if err != nil {
		panic("number of events not found")
	}

	throughput, err := strconv.Atoi(os.Getenv("SENDING_ROUTINES"))
	if err != nil {
		panic("throughput not defined")
	}

	kafkaAddr := "localhost:9092"

	client := &kafka.Writer{
		Addr:                   kafka.TCP(kafkaAddr),
		Topic:                  topicName,
		AllowAutoTopicCreation: true,
	}

	g := Generator{
		eventNumber,
		client,
	}

	g.GenerateAmplitudeLoad(throughput)
}
