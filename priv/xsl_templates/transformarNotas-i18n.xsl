<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0">
    <xsl:output indent="yes"/>
    <!--VARIABLES-->
    <xsl:variable name="idioma" select="resourcesObra/idioma"/>
    <xsl:param name="pLang" select="substring($idioma,1,2)"/>
    
    <xsl:variable name="labels" select="document('Emothe_labels.xml')/labels"/>
    
    <xsl:template match="resourcesObra">
        <html>
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                <meta http-equiv="X-UA-compatible" content="IE=8"/>
                <meta http-equiv="Content-Language" content="es"/>
                <title>
                    <xsl:value-of select="tituloObra"/>
                    <xsl:text> - </xsl:text><xsl:value-of select="$labels/etiquetas[@lang = $pLang]"/>
                </title>
                <xsl:element name="script">
                    <xsl:attribute name="type">
                        <xsl:text>text/javascript</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="src">
                        <xsl:text>../../js/jquery.js</xsl:text>
                    </xsl:attribute>
                </xsl:element>
                <xsl:element name="script">
                    <xsl:attribute name="src">
                        <xsl:text>../../js/SpryAssets/SpryAccordion.js</xsl:text>
                    </xsl:attribute>
                </xsl:element>
                <link href="../../js/SpryAssets/SpryAccordion.css" rel="stylesheet" type="text/css"/>
                <link href="../../css/estadisticas.css" rel="stylesheet" type="text/css"/>
            </head>
            <body>
                 <div id="Accordion1" class="Accordion" tabindex="0">
                    
                  <xsl:for-each-group select="rs" group-by="@tipo">
                      <xsl:sort select="current-grouping-key()"/>
                      <xsl:variable name="tipo">
                          <xsl:value-of select="current-grouping-key()"/>
                      </xsl:variable>
                      <xsl:variable name="cabeceraNota">
                          <xsl:if test="($tipo ='vestuario' or $tipo ='toponimo_accion' or $tipo ='atrezzo' or
                              $tipo ='escenografia' or $tipo ='espacio' or $tipo ='latinismo' or
                              $tipo ='oficio' or $tipo ='gesto_movimiento' or $tipo ='efectos_especiales' or
                              $tipo ='toponimo_aludido' or $tipo ='mitologia_toponimo' or $tipo ='cita_literaria' or
                              $tipo ='antroponimo' or $tipo ='mitologia_antroponimo')">
                              <xsl:value-of select="$labels/*[local-name() = $tipo][@lang=$pLang]"/>
                          </xsl:if>
                      </xsl:variable>

                      <div class="AccordionPanel">
                          <div class="AccordionPanelTab"><xsl:value-of select="$cabeceraNota"/></div>
                          <div class="AccordionPanelContent">
                          <table>
                              <tr>
                                  <td><strong><xsl:value-of select="$labels/termino[@lang = $pLang]"/></strong></td>
                                  <td><strong><xsl:value-of select="$labels/ocurrencias[@lang = $pLang]"/></strong></td>
                              </tr>
                          <xsl:for-each select="termino">
                              
                              <tr>
                                  <td>
                                      <xsl:value-of select="@name"/>
                                  </td>
                                <td>
                                    <xsl:value-of select="."/>
                                </td>
                              </tr>
                          </xsl:for-each> 
                            </table>
                          </div>
                        
                      
                      </div>
                  </xsl:for-each-group>
                  <script type="text/javascript">
                    var Acc1 = new Spry.Widget.Accordion("Accordion1", { useFixedPanelHeights: false });
                </script> 
                    
                 </div>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>