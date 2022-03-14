import faust

class value_schema(faust.Record, validation=True):
    value: str

app = faust.App('homework', broker='kafka://localhost:9092')
topic = app.topic('homework.stream.1', value_type=value_schema)

@app.agent(topic)
async def start_reading(events):
    async for event in events:
        print(event)

if __name__ == '__main__':
    app.main()
