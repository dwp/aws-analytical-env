import sys

from policy_munge.lambda_handler import lambda_handler

try:
    lambda_handler({}, {})
except Exception as e:
    print(e, file=sys.stderr)
