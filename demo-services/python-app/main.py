import sys
import logging
import fastapi
import uvicorn
import datetime
import json_logging
from fastapi import HTTPException
from starlette_prometheus import metrics, PrometheusMiddleware

app = fastapi.FastAPI()
app.add_middleware(PrometheusMiddleware)
app.add_route("/metrics", metrics)
json_logging.init_fastapi(enable_json=True)
json_logging.init_request_instrument(app)

# init the logger as usual
logger = logging.getLogger("test-logger")
logger.setLevel(logging.DEBUG)
logger.addHandler(logging.StreamHandler(sys.stdout))


@app.get("/")
def home():
    logger.info("test log statement")
    logger.info(
        "test log statement with extra props",
        extra={"props": {"extra_property": "extra_value"}},
    )
    correlation_id = json_logging.get_correlation_id()  # noqa: F841
    return "Hello world : " + str(datetime.datetime.now())


@app.get("/error")
def error():
    logger.info("This one always produces error")
    correlation_id = json_logging.get_correlation_id()  # noqa: F841
    try:
        raise "I'm broken"
    except Exception as e:  # noqa: F841
        logger.error("Broken location", exc_info=True)
        raise HTTPException(status_code=502, detail="New Error Found")


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=5000)
