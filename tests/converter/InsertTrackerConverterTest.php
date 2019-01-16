<?php
/**
 * Copyright © OXID eSales AG. All rights reserved.
 * See LICENSE file for license details.
 */

namespace sankar\ST\Tests\converter;

use toTwig\Converter\InsertTrackerConverter;
use PHPUnit\Framework\TestCase;

class InsertTrackerConverterTest extends TestCase
{

    /** @var InsertTrackerConverter */
    protected $converter;

    public function setUp()
    {
        $this->converter = new InsertTrackerConverter();
    }

    /**
     * @covers       \toTwig\Converter\InsertTrackerConverter::convert
     * @dataProvider Provider
     *
     * @param $smarty
     * @param $twig
     */
    public function testThatIncludeIsConverted($smarty, $twig)
    {
        // Test the above cases
        /** @var \SplFileInfo $fileMock */
        $fileMock = $this->getFileMock();
        $this->assertSame($twig, $this->converter->convert($fileMock, $smarty));
    }

    public function Provider()
    {
        return [
            [
                '[{insert name="oxid_tracker" title="PRODUCT_DETAILS"|oxmultilangassign product=$oDetailsProduct cpath=$oView->getCatTreePath()}]',
                '{{ insert_tracker({title: "PRODUCT_DETAILS"|translate, product: oDetailsProduct, cpath: oView.getCatTreePath()}) }}'
            ],
            [
                '[{ insert name="oxid_tracker" title="PRODUCT_DETAILS"|oxmultilangassign product=$oDetailsProduct cpath=$oView->getCatTreePath() }]',
                '{{ insert_tracker({title: "PRODUCT_DETAILS"|translate, product: oDetailsProduct, cpath: oView.getCatTreePath()}) }}'
            ]
        ];
    }

    /**
     * @covers \toTwig\Converter\InsertTrackerConverter::getName
     */
    public function testThatHaveExpectedName()
    {
        $this->assertEquals('oxid_tracker', $this->converter->getName());
    }

    /**
     * @covers \toTwig\Converter\InsertTrackerConverter::getDescription
     */
    public function testThatHaveDescription()
    {
        $this->assertNotEmpty($this->converter->getDescription());
    }

    private function getFileMock()
    {
        return $this->getMockBuilder('\SplFileInfo')->disableOriginalConstructor()->getMock();
    }
}