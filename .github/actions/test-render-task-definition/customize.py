#!/usr/bin/env python
# -*- coding: utf-8 -*-
""" Setup configurations for the j2cli

:see: https://github.com/kolypto/j2cli#customization
"""

import yaml
import os

# Loader
try:
    # PyYAML 5.1 supports FullLoader
    Loader = yaml.FullLoader
except AttributeError:
    # Have to use SafeLoader for older versions
    Loader = yaml.SafeLoader

__DIR__ = os.path.dirname(os.path.realpath(__file__))


def alter_context(context):
    """ Modify the context and return it """
    context.update({'default': 'yes'})
    return context
