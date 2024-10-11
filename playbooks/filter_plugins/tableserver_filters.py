#!/usr/bin/python

import unittest

class FilterModule(object):
    def filters(self):
        return {
            'to_factory': self.to_factory,
            'to_server_list': self.to_server_list
        }

    def to_factory(self, hostname):
        factory_number = [int(s) for s in hostname.split("-") if s.isdigit()][0]
        if "non-gdk" in hostname:
            factory_number = factory_number + 10
        return f"ip:c_zn1_factory{factory_number}address:port"

    def to_server_list(self, hostname):
        factory = self.to_factory(hostname)
        return f"{factory},3"

class TestFilterModule(unittest.TestCase):
    def setUp(self) -> None:
        self.filter_module = FilterModule()

    def test_to_factory(self):
        hostname = "ggn-gdk-2-preprod"
        expected_output = "ip:c_zn1_factory2address:port"
        self.assertEqual(self.filter_module.to_factory(hostname), expected_output)

    def test_nongdk_to_factory(self):
        hostname = "ggn-non-gdk-2-preprod"
        expected_output = "ip:c_zn1_factory12address:port"
        self.assertEqual(self.filter_module.to_factory(hostname), expected_output)

    def test_to_server_list(self):
        hostname = "ggn-gdk-1-preprod"
        expected_output = "ip:c_zn1_factory1address:port,3"
        self.assertEqual(self.filter_module.to_server_list(hostname), expected_output)

    def test_nongdk_to_server_list(self):
        hostname = "ggn-non-gdk-1-preprod"
        expected_output = "ip:c_zn1_factory11address:port,3"
        self.assertEqual(self.filter_module.to_server_list(hostname), expected_output)

if __name__ == '__main__':
    unittest.main()
