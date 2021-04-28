import hashlib


def str_md5_digest(string: str) -> str:
    return hashlib.md5(string.encode("utf-8")).hexdigest()
