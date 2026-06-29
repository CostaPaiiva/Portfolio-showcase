import unittest

import pandas as pd

from data_processing import PowerfulDataProcessor
from tests.test_support import AutoMLTestSupport


class TestProcessing(unittest.TestCase, AutoMLTestSupport):
    def setUp(self):
        self.tmpdir, self.dataframe, self.csv_path = self.prepare_csv()
        self.addCleanup(self.tmpdir.cleanup)

    def test_upload_and_processing(self):
        processor = PowerfulDataProcessor(target_column="target", problem_type="auto")
        X_processed, y_processed, problem_type = processor.process(data=pd.read_csv(self.csv_path))

        self.assertEqual(problem_type, "classification")
        self.assertEqual(len(X_processed), len(y_processed))
        self.assertGreaterEqual(X_processed.shape[1], 1)

    def test_regression_processing(self):
        tmpdir, dataframe, csv_path = self.prepare_regression_csv()
        self.addCleanup(tmpdir.cleanup)

        processor = PowerfulDataProcessor(target_column="target", problem_type="auto")
        X_processed, y_processed, problem_type = processor.process(data=pd.read_csv(csv_path))

        self.assertEqual(problem_type, "regression")
        self.assertEqual(len(X_processed), len(y_processed))
        self.assertTrue(pd.api.types.is_numeric_dtype(y_processed))
        self.assertGreaterEqual(X_processed.shape[1], 1)


if __name__ == "__main__":
    unittest.main()
