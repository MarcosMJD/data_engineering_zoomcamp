from turtle import clear
from kafka import KafkaConsumer, KafkaProducer
from json import loads, dumps
from time import sleep
import datetime

topic_1 = 'homework.stream.1'
topic_2 = 'homework.stream.2'
values_streams = {}

def join_dicts(dicts, ids):

  joined = {}
  for i, dict in enumerate(dicts):
    id = ids[i].replace('.','_')
    for key in dict.keys():
      joined[f'{id}_{key}'] = dict[key]
  return joined

def join_values(values_streams):

  joined = []
  for topic, values in values_streams.items():
    if values:
      for value in values:
        if not value['joined']:
          for _topic, _values in values_streams.items():
            if _topic is not topic:
              if _values:
                for _value in _values:
                  if not _value['joined'] or _value == _values[-1]:
                    joined.append(join_dicts((value,_value), (topic, _topic)))
                    value['joined'] = True
                    _value['joined'] = True
  return joined

  
def join_streams(*args):

  global values_streams

  consumer = KafkaConsumer(
    *args,
    bootstrap_servers=['localhost:9092'],
    auto_offset_reset='earliest',
    enable_auto_commit=False,
    group_id='homework.group.1',
    value_deserializer=lambda x: loads(x.decode('utf-8')))

  producer = KafkaProducer(
      bootstrap_servers=['localhost:9092'],
      key_serializer=lambda x: dumps(x).encode('utf-8'),
      value_serializer=lambda x: dumps(x).encode('utf-8'))


  for topic in args:
    values_streams[topic] = []

  start_window_time = 0
  window_size = 10000

  while True:
      print('Running')
      for message in consumer:

          if start_window_time == 0:
            start_window_time = message.timestamp
          else:
            if message.timestamp > start_window_time + window_size:
              start_window_time += window_size
              print(f'Start new window at {start_window_time}')
              for topic in args:
                values_streams[topic] = []

          values_streams[message.topic].append({"value": message.value, "joined": False})
          joined_values = join_values(values_streams)
          for value in joined_values:
            producer.send("homework.stream.joined", key=1, value=value)
          consumer.commit()
      sleep(1)

if __name__ == '__main__':
  join_streams(topic_1, topic_2)

