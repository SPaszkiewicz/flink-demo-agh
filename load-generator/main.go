package main

import (
	"github.com/segmentio/kafka-go"
	"os"
	"strconv"
)

func main() {
	kafkaAddr := os.Getenv("KAFKA_IP")
	if kafkaAddr == "" {
		panic("kafka address not found")
	}

	topicName := os.Getenv("TOPIC_NAME")
	if kafkaAddr == "" {
		panic("topic name not found")
	}

	eventNumber, err := strconv.Atoi(os.Getenv("EVENTS_NUM"))
	if err != nil {
		panic("number of events not found")
	}

	client := &kafka.Writer{
		Addr:                   kafka.TCP(kafkaAddr),
		Topic:                  topicName,
		AllowAutoTopicCreation: true,
	}

	g := Generator{
		eventNumber,
		client,
	}

	g.GenerateAmplitudeLoad()
}
