package main

import (
	"encoding/json"
	"fmt"
	"time"
)

// WaybarOutput defines the exact JSON structure Waybar expects
type WaybarOutput struct {
	Text    string `json:"text"`
	Tooltip string `json:"tooltip"`
}

func main() {
	// 1. Calculate the current Martian Sol dynamically
	baseSol := 4200
	currentSol := baseSol + time.Now().YearDay()

	// 2. Generate a realistic sub-zero Martian temperature based on the hour of the day
	hour := time.Now().Hour()
	var marsTemp int
	if hour > 6 && hour < 18 {
		marsTemp = -35 + (hour % 15) // Warmer Martian midday
	} else {
		marsTemp = -75 - (hour % 10) // Frozen Martian night
	}

	// 3. Set the telemetry layout strings
	text := fmt.Sprintf("🪐 %d°C", marsTemp)
	tooltip := fmt.Sprintf("🔴 Mars Environmental Telemetry\n----------------------------\n⏳ Chronos: Sol %d\n✨ Atmospheric Condition: Clear &amp; Dry\n🌡️ Ambient Temperature: %d°C\n💨 Surface Wind: 14 m/s\n🧬 Radiation UV Index: High\n📡 Pressure: 6.1 hPa", currentSol, marsTemp)
	// 4. Marshal into pristine JSON
	output := WaybarOutput{
		Text:    text,
		Tooltip: tooltip,
	}

	jsonData, err := json.Marshal(output)
	if err != nil {
		fmt.Println(`{"text": "🪐 Err", "tooltip": "JSON Marshal Error"}`)
		return
	}

	fmt.Println(string(jsonData))
}
