import pytest

from whats_my_ip import ip_service


MOCKED_IP_ADDRESS = "74.125.151.217"
LOCAL_IP_ADDRESS = "127.0.0.1"


class MockedResponse:
    def __init__(self, status_code, text) -> None:
        self.status_code = status_code
        self.text = text


def test_get_public_ip_from_external_service_200(mocker):
    response = MockedResponse(200, MOCKED_IP_ADDRESS)
    mocker.patch(
        'requests.get',
        return_value=response,
    )
    assert MOCKED_IP_ADDRESS == ip_service.get_public_ip_from_external_service()


def test_get_public_ip_from_external_service_500(mocker):
    response = MockedResponse(500, None)
    mocker.patch(
        'requests.get',
        return_value=response,
    )
    with pytest.raises(RuntimeError):
        ip_service.get_public_ip_from_external_service()


def test_get_client_ip_without_proxy():
    headers = {
        ip_service.CLIENT_IP_HEADER_NO_PROXY: MOCKED_IP_ADDRESS
    }
    assert MOCKED_IP_ADDRESS == ip_service.get_client_ip(headers)


def test_get_client_ip_with_proxy():
    headers = {
        ip_service.CLIENT_IP_HEADER_NO_PROXY: LOCAL_IP_ADDRESS,
        ip_service.CLIENT_IP_HEADER_BEHIND_PROXY: MOCKED_IP_ADDRESS
    }
    assert MOCKED_IP_ADDRESS == ip_service.get_client_ip(headers)


def test_get_client_ip_external_service_available(mocker):
    headers = {
        ip_service.CLIENT_IP_HEADER_NO_PROXY: LOCAL_IP_ADDRESS,
    }
    mocker.patch(
        'whats_my_ip.ip_service.get_public_ip_from_external_service',
        return_value=MOCKED_IP_ADDRESS)
    assert MOCKED_IP_ADDRESS == ip_service.get_client_ip(headers)


def test_get_client_ip_external_service_unavailable(mocker):
    headers = {
        ip_service.CLIENT_IP_HEADER_NO_PROXY: LOCAL_IP_ADDRESS,
    }
    mocker.patch(
        'whats_my_ip.ip_service.get_public_ip_from_external_service',
        side_effect=RuntimeError)
    assert None == ip_service.get_client_ip(headers)
