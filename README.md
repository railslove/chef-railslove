[![Build Status](https://travis-ci.org/railslove/chef-railslove.png?branch=master)](https://travis-ci.org/railslove/chef-railslove)

Description
===========

Requirements
============

Attributes
==========

#### railslove::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['railslove']['packages']</tt></td>
    <td>Array</td>
    <td></td>
    <td><tt>[]</tt></td>
  </tr>
  <tr>
    <td><tt>['railslove']['companies']</tt></td>
    <td>Array</td>
    <td></td>
    <td><tt>["railslove"]</tt></td>
  </tr>
  <tr>
    <td><tt>['railslove']['domain']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>railslabs.com</tt></td>
  </tr>
  <tr>
    <td><tt>['railslove']['manage_dns_records']</tt></td>
    <td>Boolean</td>
    <td></td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>['railslove']['route53']['databag']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>aws</tt></td>
  </tr>
  <tr>
    <td><tt>['railslove']['route53']['item']</tt></td>
    <td>String</td>
    <td></td>
    <td><tt>route53</tt></td>
  </tr>
</table>

Usage
=====

