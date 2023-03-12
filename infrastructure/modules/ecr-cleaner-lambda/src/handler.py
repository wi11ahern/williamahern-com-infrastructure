from typing import List, Dict
import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

client = boto3.client("ecr")


def lambda_handler(event, context):
    registry_id: str = event.get("registryId")
    repository_name: str = event.get("repositoryName")
    image_ids = get_image_ids(registry_id=registry_id, repository_name=repository_name)
    if not image_ids:
        logger.info("There are no images to delete.")
        return

    delete_was_successful = batch_delete_images(
        registry_id=registry_id, repository_name=repository_name, image_ids=image_ids
    )
    if not delete_was_successful:
        logger.info("Failed to delete all images.")
    else:
        logger.info("All images successfully deleted.")


def get_image_ids(registry_id: str, repository_name: str) -> List[Dict[str, str]]:
    next_token = None
    list_image_args = {
        "registryId": registry_id,
        "repositoryName": repository_name,
        "nextToken": next_token,
        "maxResults": 100,
        "filter": {"tagStatus": "ANY"},
    }
    image_ids: List[str] = []

    try:
        while True:
            logger.info("Fetching batch of image IDs...")

            non_none_list_image_args = {
                k: v for k, v in list_image_args.items() if v is not None
            }
            response = client.list_images(**non_none_list_image_args)
            response_image_ids = response.get("imageIds", [])
            image_ids += response_image_ids
            logger.info(f"Batch of image IDs fetched:\n{response_image_ids}")

            next_token = response.get("nextToken", "")
            if not next_token:
                break
            else:
                list_image_args["nextToken"] = next_token

    except Exception as e:
        logger.error(f"Encountered failure when listing images.\n{e}")

    finally:
        return image_ids


def batch_delete_images(
    registry_id: str, repository_name: str, image_ids: List[Dict[str, str]]
):
    delete_was_successful = False
    try:
        logger.info(f"Deleting batch of image IDs:\n{image_ids}")
        response = client.batch_delete_image(
            registryId=registry_id,
            repositoryName=repository_name,
            imageIds=image_ids,
        )
        delete_was_successful = True
        logger.info(f"Batch of image IDs delete:\n{image_ids}")

    except Exception as e:
        logger.error(f"Encountered failure when deleting images.\n{e}")

    finally:
        return delete_was_successful
