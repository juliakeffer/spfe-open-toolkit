<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
 exclude-result-prefixes="#all">

<xsl:param name="message-types">info debug warning</xsl:param>
<xsl:param name="terminate-on-error">yes</xsl:param>
<xsl:variable name="verbosity" select="tokenize($message-types, ' ')"/>

<xsl:function name="sf:title2anchor">
	<xsl:param name="title"/>
	<xsl:value-of select='translate( normalize-space($title), " :&apos;[]", "-----")'/>
</xsl:function>

<xsl:function name="sf:get-sources">
	<xsl:param name="file-list"/>
	<xsl:sequence select="sf:get-sources($file-list, '')"></xsl:sequence>
</xsl:function>
	
<xsl:function name="sf:get-sources">
	<xsl:param name="file-list"/>
	<xsl:param name="load-message"/>
	
	<xsl:for-each select="tokenize(translate($file-list, '\', '/'), ';')">
		<xsl:variable name="one-file" select="concat('file:///', normalize-space(.))"/>
		<xsl:if test="normalize-space($load-message)">
			<xsl:call-template name="sf:info">
				<xsl:with-param name="message" select="$load-message, $one-file "/>
			</xsl:call-template>
		</xsl:if>
		<xsl:sequence select="document($one-file)"/>
	</xsl:for-each>
</xsl:function>	
	
	<xsl:template name="sf:info">
		<xsl:param name="message"/>
		<xsl:if test="$verbosity='info'">
			<xsl:message select="'Info: ', $message"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="sf:debug">
		<xsl:param name="message"/>
		<xsl:if test="$verbosity='debug'">
			<xsl:message select="'Debug: ', $message"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="sf:warning">
		<xsl:param name="message"/>
		<xsl:if test="$verbosity='warning'">
			<xsl:message>
				<xsl:text>Warning: </xsl:text>
				<xsl:sequence select="$message"/>
			</xsl:message>
		</xsl:if>
	</xsl:template>

	<xsl:template name="sf:mention-not-resolved">
		<xsl:param name="message"/>
		<xsl:if test="$verbosity='warning'">
			<xsl:message>
				<xsl:text>Mention not resolved: </xsl:text>
				<xsl:sequence select="$message"/>
			</xsl:message>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="sf:error">
		<xsl:param name="message"/>
		<xsl:message>**********************************************************</xsl:message>
		<xsl:message select="'ERROR: ', string-join($message,'')"/>
		<xsl:message>**********************************************************</xsl:message>
		<xsl:message terminate="{$terminate-on-error}"/>
	</xsl:template>
	

	<xsl:function name="sf:path-depth">
		<!-- Calculates the depth of an XPath by counting the number of 
		elements in the path. It uses tokenize to count but throws away 
		the empty string item that would be created by a leading or trailing 
		slash. Thus foo/bar, /foo/bar, and /foo/bar/, are all counted as
		having a path depth of 2. Will count a concluding attribute on a 
		path as part of the depth. Presumably works for file paths as well,
		as long as they are in UNIX form. -->
		<xsl:param name="path"/>
		<xsl:value-of select="count(tokenize($path, '/')[. ne ''])"/>
	</xsl:function>

	<xsl:function name="sf:get-file-name-from-path">
		<xsl:param name="path"/>
		<xsl:variable name="tokens" select="tokenize($path, '/')"/>
		<xsl:value-of select="subsequence($tokens, count($tokens))"/>
	</xsl:function>

	<xsl:function name="sf:string" >
		<xsl:param name="strings" as="element()*"/>
		<xsl:param name="id"/>
		<xsl:if test="not($strings/*:string[@id=$id])">
			<xsl:call-template name="sf:error">
				<xsl:with-param name="message">String lookup failed for string ID <xsl:value-of select="$id"/>. No matching string found.</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:sequence select="$strings/*:string[@id=$id]/node()"/>
	</xsl:function>

	<!-- returns the index of the longest of a set of strings -->
	<xsl:function name="sf:longest-string" as="xs:integer">
		<xsl:param name="strings"/>
		<xsl:value-of select="sf:get-longest($strings,1,1)"/>
	</xsl:function>
	
	<xsl:function name="sf:get-longest" as="xs:integer">
	<xsl:param name="strings"/>
	<xsl:param name="current"/>
	<xsl:param name="longest"/>
	<xsl:choose>
		<xsl:when test="$current lt count($strings)">
			<xsl:variable name="new-longest">
				<xsl:choose>
					<xsl:when test="string-length($strings[$current]) gt string-length($strings[$longest])">
						<xsl:value-of select="string-length($strings[$current])"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:value-of select="sf:get-longest($strings,$current + 1, $new-longest)"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$longest"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="sf:conditions-met" as="xs:boolean">
	<xsl:param name="conditions"/>
	<xsl:param name="condition-tokens"/>
	<xsl:variable name="tokens-list" select="tokenize($condition-tokens, '\s+')"/>
	<xsl:variable name="conditions-list" select="tokenize($conditions, '\s+')"/>
	<xsl:choose>
		<xsl:when test="not($conditions)">
			<xsl:value-of select="true()"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="sf:satisfies-condition($conditions-list, $tokens-list)"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>
	
	<xsl:function name="sf:file-name-from-uri">
		<xsl:param name="uri"/>
		<xsl:value-of select="substring-before(tokenize($uri, '/')[count(tokenize($uri, '/'))], '.xml')"/>
	</xsl:function>

<xsl:function name="sf:satisfies-condition" as="xs:boolean">
	<xsl:param name="conditions-list"/>
	<xsl:param name="tokens-list"/>
	<xsl:value-of select="sf:satisfies-condition($conditions-list, $tokens-list, 1)"/>
</xsl:function>

<xsl:function name="sf:satisfies-condition" as="xs:boolean">
	<xsl:param name="conditions-list"/>
	<xsl:param name="tokens-list"/>
	<xsl:param name="index"/>
	
	<xsl:variable name="and-tokens" select="tokenize($tokens-list[$index], '\+')"/>
	
	<xsl:choose>
		<xsl:when test="every $item in $and-tokens satisfies $item=$conditions-list">
			<xsl:value-of select="true()"/>
		</xsl:when>
		<xsl:when test="$index lt count($tokens-list)">
			<xsl:value-of select="sf:satisfies-condition($conditions-list, $tokens-list, $index + 1)"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="false()"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>
</xsl:stylesheet>
