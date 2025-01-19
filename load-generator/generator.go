package main

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/itchyny/timefmt-go"
	"github.com/segmentio/kafka-go"
	"math/rand"
	"strconv"
	"time"
)

// AmplitudeEvent based on api: https://amplitude.com/docs/apis/analytics/http-v2
type AmplitudeEvent struct {
	UserId         string            `json:"user_id"`
	EventType      string            `json:"event_type"`
	UserProperties map[string]string `json:"user_properties"`
	Country        string            `json:"country"`
	Ip             string            `json:"ip"`
	Time           int64             `json:"time"`
}

type Generator struct {
	NumOfEvents int
	kafkaClient *kafka.Writer
}

var userEvents = []string{"click", "drag", "point", "scroll"}
var userKeys = []string{"LeftMouse", "RightMouse", "Enter", "Tab", "Shift"}
var countries = []string{"USA", "UK", "Poland", "Germany", "Kirghistan"}
var httpMethods = []string{"GET", "POST", "PUT", "DELETE", "HEAD", "TRACE"}
var httpPaths = []string{"/v1/users", "/favicon.ico", "/v1/home", "/shop/card/current", "/", "/accounts"}
var statusCodes = []string{"200", "302", "403", "401", "400"}

func (g *Generator) GenerateAmplitudeLoad(throughput int) {
	routineLimiter := make(chan struct{}, throughput)

	for i := 0; i < g.NumOfEvents; i++ {
		routineLimiter <- struct{}{}
		userId := fmt.Sprintf("USR_%d", rand.Intn(100))
		eventType := userEvents[rand.Intn(len(userEvents))]
		userProperties := make(map[string]string)
		country := countries[rand.Intn(len(countries))]
		userIp := fmt.Sprintf("%d.%d.%d.%d", rand.Intn(200), rand.Intn(200), rand.Intn(200), rand.Intn(200))

		switch eventType {
		case "click":
			userProperties["key"] = userKeys[rand.Intn(len(userKeys))]
			break
		case "scroll":
			userProperties["delta"] = strconv.Itoa(rand.Intn(600) - 300)
			break
		}

		event := AmplitudeEvent{
			UserId:         userId,
			EventType:      eventType,
			UserProperties: userProperties,
			Country:        country,
			Ip:             userIp,
			Time:           time.Now().Unix(),
		}

		encodedEvent, err := json.Marshal(event)

		if err != nil {
			fmt.Printf("error occured: %s", err.Error())
		}

		msg := kafka.Message{
			Key:   []byte(""),
			Value: encodedEvent,
			Time:  time.Now(),
		}

		go func() {
			err = g.kafkaClient.WriteMessages(context.Background(), msg)

			if err != nil {
				fmt.Printf("error occured: %s", err.Error())
			}
			time.Sleep(100 * time.Millisecond)
			<-routineLimiter
		}()
	}
}

// GenerateApacheLoad based on the apache log format https://httpd.apache.org/docs/2.4/logs.html
func (g *Generator) GenerateApacheLoad() {
	for i := 0; i < g.NumOfEvents; i++ {
		go func() {
			userId := fmt.Sprintf("USR_%d", rand.Intn(100))
			userIp := fmt.Sprintf("%d.%d.%d.%d", rand.Intn(200), rand.Intn(200), rand.Intn(200), rand.Intn(200))
			sc := statusCodes[rand.Intn(len(statusCodes))]
			path := httpPaths[rand.Intn(len(httpPaths))]
			method := httpMethods[rand.Intn(len(httpMethods))]
			size := rand.Intn(3600)
			t := time.Now()
			userTime := timefmt.Format(t, "%d/%b/%Y:%H:%M:%S %z")

			event := fmt.Sprintf("%s - %s [%s] \"%s %s HTTP/1.0\" %s %d", userIp, userId, userTime, method, path, sc, size)

			msg := kafka.Message{
				Key:   []byte(""),
				Value: []byte(event),
				Time:  time.Now(),
			}

			time.Sleep(time.Millisecond * 100)
			err := g.kafkaClient.WriteMessages(context.Background(), msg)
			if err != nil {
				fmt.Printf("error occured: %s", err.Error())
			}
		}()
	}
}
