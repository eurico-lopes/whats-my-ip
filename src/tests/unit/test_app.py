from whats_my_ip import application


MOCKED_IP_ADDRESS = "74.125.151.217"


def test_get_ip_available(mocker):
    with application.app.test_request_context(): # this mocks request.environ
        mocker.patch(
            'whats_my_ip.application.get_client_ip',
            return_value=MOCKED_IP_ADDRESS,
        )
        html_text = application.get()

    assert f"Your public IP is {MOCKED_IP_ADDRESS}!" in html_text

def test_get_ip_unavailable(mocker):
    with application.app.test_request_context(): # this mocks request.environ
        mocker.patch(
            'whats_my_ip.application.get_client_ip',
            return_value=None,
        )
        html_text = application.get()
    assert "Public IP Service is not available at the moment, please try again later!" in html_text
