import socket

import pulse


def test_disk_ok_with_high_limit():
    assert pulse.check_disk("/", limit=101)["ok"] is True


def test_disk_fails_with_zero_limit():
    assert pulse.check_disk("/", limit=0)["ok"] is False


def test_dns_resolves_localhost():
    assert pulse.check_dns("localhost")["ok"] is True


def test_dns_fails_for_invalid_name():
    assert pulse.check_dns("does-not-exist.invalid")["ok"] is False


def test_tcp_open_port():
    server = socket.socket()
    server.bind(("127.0.0.1", 0))
    server.listen(1)
    port = server.getsockname()[1]
    try:
        assert pulse.check_tcp("127.0.0.1", port)["ok"] is True
    finally:
        server.close()


def test_tcp_closed_port():
    # bind to get a free port number, then close it so nothing is listening
    sock = socket.socket()
    sock.bind(("127.0.0.1", 0))
    port = sock.getsockname()[1]
    sock.close()
    assert pulse.check_tcp("127.0.0.1", port, timeout=1)["ok"] is False
