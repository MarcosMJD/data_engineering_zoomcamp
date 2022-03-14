from kafka import KafkaProducer
from time import sleep
from json import dumps

producer = KafkaProducer(
    bootstrap_servers=['localhost:9092'],
    key_serializer=lambda x: dumps(x).encode('utf-8'),
    value_serializer=lambda x: dumps(x).encode('utf-8'))

for i in range(1000):
    key = {"id": 1}
    value = {"value": f'stream2_{i}'}

    producer.send("homework.stream.2", key=key, value=value)
    print(f'producing key {["id"]} value {value["value"]}')
    sleep(1)