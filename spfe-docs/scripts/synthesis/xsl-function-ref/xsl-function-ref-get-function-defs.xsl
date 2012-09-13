<?xml version="1.0" encoding="UTF-8"?>
    <!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
    <!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    version="2.0"
    >

    <xsl:import href="http://spfeopentoolkit.org/spfe-ot/1.0/scripts/common/utility-functions.xsl"/>
    
    <xsl:output indent="yes"/>
    
    <xsl:variable name="config" as="element(config:spfe)">
        <xsl:sequence select="/config:spfe"/>
    </xsl:variable>
    
    <xsl:param name="xslt-files"/>
    <xsl:variable name="xslt-file-set" select="sf:get-sources($xslt-files)"/>
    
    <xsl:template name="main">
      <function-definitions>
        <xsl:apply-templates select="$xslt-file-set"/>
      </function-definitions>
    </xsl:template>
    
    <xsl:template match="xsl:*">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="*/text()"/>
    
    <xsl:template match="xsl:function">
        <function-definition>
            <name>
                <xsl:value-of select="substring-before(@name, ':')"/>
            </name>
            <local-prefix>
                <xsl:value-of select="substring-before(@name, ':')"/>
            </local-prefix>
            <source-file>
                <xsl:value-of select="base-uri()"></xsl:value-of>
            </source-file>
            <namespace-uri>
                <xsl:value-of select="namespace-uri-for-prefix(substring-before(@name, ':'), .)"/>
            </namespace-uri>
            <parameters>
                <xsl:for-each select="xsl:param">
                    <parameter>
                        <name><xsl:value-of select="@name"/></name>
                        <type><xsl:value-of select="@as"/></type>
                    </parameter>
                </xsl:for-each>
            </parameters>
        </function-definition>
    </xsl:template>
   

    

</xsl:stylesheet>