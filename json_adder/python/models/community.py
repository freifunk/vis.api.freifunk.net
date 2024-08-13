from dataclasses import dataclass
from bson.datetime_ms import DatetimeMS
from dataclasses import asdict

@dataclass
class Community:
    metadata: str
    timestamp: DatetimeMS
    content: dict

    def to_bson(self):
        return asdict(self)
