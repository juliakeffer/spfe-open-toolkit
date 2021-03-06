<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">

    <xsl:template match="*:spfe-config-element-name">
        <xsl:element name="name" namespace="{$output-namespace}">
            <xsl:attribute name="type">xpath</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(if (@xpath) then @xpath else .)"/>
            <xsl:attribute name="namespace">http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config</xsl:attribute> 
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>    
    
    <xsl:template match="*:spfe-config-attribute-name">
        <xsl:element name="name" namespace="{$output-namespace}">
            <xsl:attribute name="type">xpath</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(if (@xpath) then @xpath else .)"/>
            <xsl:attribute name="namespace">http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config</xsl:attribute>             <xsl:if test="@namespace">
                <xsl:attribute name="namespace" select="@namespace"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>   
    
    <xsl:template match="*:spfe-build-property">
        <xsl:element name="name" namespace="{$output-namespace}">
            <xsl:attribute name="type">spfe-build-property</xsl:attribute>
            <xsl:attribute name="key" select="normalize-space(.)"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
 </xsl:stylesheet>