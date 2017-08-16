#!/usr/bin/env python

from vnc_api import vnc_api
import argparse


def virtual_network_locate(vn_name):
        fq_name = vn_name.split(':')
        try:
            vn_instance = client.virtual_network_read(fq_name=fq_name)
            print "Virtual network '%s' already exists" % vn_name
            return vn_instance
        except vnc_api.NoIdError:
            pass

        vn_name = fq_name[2]
        vn_instance = vnc_api.VirtualNetwork(vn_name)
        vn_instance.add_network_ipam(vnc_api.NetworkIpam(),
                                     vnc_api.VnSubnetsType([vnc_api.IpamSubnetType(subnet = vnc_api.SubnetType('20.1.1.0', 24))]))
        client.virtual_network_create(vn_instance)
        print "Virtual network '%s' created" % vn_name
        return vn_instance


parser = argparse.ArgumentParser(description='Create a virtual network')
parser.add_argument('--api-server-host', type=str, default='localhost')
parser.add_argument('--api-server-port', type=str, default='8082')

parser.add_argument('virtual_network_fqname', type=str)

args = parser.parse_args()

# We create resources in the contrail api
client = vnc_api.VncApi(username='api-server', password='api-server',
                        tenant_name='admin',
                        api_server_host=args.api_server_host,
                        api_server_port=args.api_server_port)

virtual_network_locate(args.virtual_network_fqname)
