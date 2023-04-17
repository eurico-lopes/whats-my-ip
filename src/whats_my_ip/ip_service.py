import ipaddress

import requests


CLIENT_IP_HEADER_BEHIND_PROXY = "HTTP_X_FORWARDED_FOR"
CLIENT_IP_HEADER_NO_PROXY = "REMOTE_ADDR"
PUBLIC_IP_SERVICE_URL = "http://checkip.amazonaws.com"


def get_client_ip(headers: dict):
    """
        Receives the headers and tries to take an ip address from them.
        If the IP address is private, we get the public IP from a separate service.
    """
    client_ip = headers.get(CLIENT_IP_HEADER_NO_PROXY)
    if headers.get(CLIENT_IP_HEADER_BEHIND_PROXY):
        client_ip = headers.get(CLIENT_IP_HEADER_BEHIND_PROXY)
    if ipaddress.ip_address(client_ip).is_private: # if IP is private, it means we are in the same local network.
        try:
            client_ip = get_public_ip_from_external_service()
        except:
            client_ip = None
    return client_ip


def get_public_ip_from_external_service():
    response = requests.get(PUBLIC_IP_SERVICE_URL)
    if response.status_code == 200:
        return response.text.strip()
    raise RuntimeError("Public IP Server unavailable")
        