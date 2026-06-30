---
title: 六大基础排序算法
date: 2026-06-25 16:00 +0800
categories: [Blogs, Learn]
tags: [cpp, sorting]
---

## 排序算法

### 1. 插入排序

具体来说，我们在未排序区间选择一个基准元素，将该元素与其左侧已排序区间的元素逐一比较大小，并将该元素插入到正确的位置。
实际上，许多编程语言（例如 Java）的内置排序函数采用了插入排序，大致思路为：对于长数组，采用基于分治策略的排序算法，例如快速排序；对于短数组，直接使用插入排序。

```cpp
/* 插入排序 */
void insertionSort(vector<int> &nums) {
    // 外循环：已排序区间为 [0, i-1]
    for (int i = 1; i < nums.size(); i++) {
        int base = nums[i], j = i - 1;
        // 内循环：将 base 插入到已排序区间 [0, i-1] 中的正确位置
        while (j >= 0 && nums[j] > base) {
            nums[j + 1] = nums[j]; // 将 nums[j] 向右移动一位
            j--;
        }
        nums[j + 1] = base; // 将 base 赋值到正确位置
    }
}
```

### 2. 选择排序

开启一个循环，每轮从未排序区间选择最小的元素，将其放到已排序区间的末尾。

```cpp
/* 选择排序 */
void selectionSort(vector<int> &nums) {
    int n = nums.size();
    // 外循环：未排序区间为 [i, n-1]
    for (int i = 0; i < n - 1; i++) {
        // 内循环：找到未排序区间内的最小元素
        int k = i;
        for (int j = i + 1; j < n; j++) {
            if (nums[j] < nums[k])
                k = j; // 记录最小元素的索引
        }
        // 将该最小元素与未排序区间的首个元素交换
        swap(nums[i], nums[k]);
    }
}
```

### 3. 希尔排序

插排的升级版，核心思想是“越有序，插排越快”。
选定一个间隔（比如总长度的一半）把数组“分组”。对每一组内的元素进行直接插入排序。因为组内元素很少，所以排得很快。
缩小间隔（通常减半），重复分组和排序。直到间隔变为 1，此时整个数组基本有序，再做最后一次完整的插入排序收尾。

```cpp
void shellSort(std::vector<int> &nums) {
    int n = nums.size();
    // 1. 初始步长设为数组长度的一半，之后每次减半，直到步长为1
    for (int gap = n / 2; gap > 0; gap /= 2) {
        // 2. 从第 gap 个元素开始，对其所属的“分组”进行插入排序
        for (int i = gap; i < n; i++) {
            int temp = nums[i];
            int j = i;
            // 3. 在组内向前比较：如果前一个元素比 temp 大，就把它往后挪
            while (j >= gap && nums[j - gap] > temp) {
                nums[j] = nums[j - gap];
                j -= gap;
            }
            // 4. 把 temp 插入到正确的位置
            nums[j] = temp;
        }
    }
}
```

### 4. 链表归并排序

划分阶段：通过递归不断地将数组从中点处分开，将长数组的排序问题转换为短数组的排序问题。
合并阶段：当子数组长度为 1 时终止划分，开始合并，持续地将左右两个较短的有序数组合并为一个较长的有序数组，直至结束。

```cpp
ListNode *mergeSort(ListNode *head) {
    // 1. 递归终止条件：链表为空或只有一个节点时，天然有序
    if (!head || !head->next)
        return head;

    // 2. 快慢指针找中点
    ListNode *slow = head;
    // 注意：fast先走一步，防止偶数长度时slow偏右
    ListNode *fast = head->next;

    while (fast && fast->next) {
        slow = slow->next;
        fast = fast->next->next;
    }

    // 3. 断开链表，分成左右两半
    ListNode *mid = slow->next;
    slow->next = nullptr;

    // 4. 递归排序左右两半
    ListNode *left = mergeSort(head);
    ListNode *right = mergeSort(mid);

    // 5. 合并两个有序链表
    return merge(left, right);
}

// 合并两个有序链表（基础操作）
ListNode *merge(ListNode *l1, ListNode *l2) {
    ListNode dummy(0); // 虚拟头节点，方便操作
    ListNode *curr = &dummy;

    while (l1 && l2) {
        if (l1->val <= l2->val) {
            curr->next = l1;
            l1 = l1->next;
        } else {
            curr->next = l2;
            l2 = l2->next;
        }
        curr = curr->next;
    }
    // 将剩余的节点接上
    curr->next = (l1 != nullptr) ? l1 : l2;

    return dummy.next;
}
```

对于链表，归并排序相较于其他排序算法具有显著优势，可以将链表排序任务的空间复杂度优化至 O(1)。

划分阶段：可以使用“迭代”替代“递归”来实现链表划分工作，从而省去递归使用的栈帧空间。
合并阶段：在链表中，节点增删操作仅需改变引用（指针）即可实现，因此合并阶段（将两个短有序链表合并为一个长有序链表）无须创建额外链表。

### 5. 快速排序

快速排序的核心操作是“哨兵划分”，其目标是：选择数组中的某个元素作为“基准数”，将所有小于基准数的元素移到其左侧，而大于基准数的元素移到其右侧。具体来说，哨兵划分的流程如图 11-8 所示。

1. 选取数组最左端元素作为基准数，初始化两个指针 i 和 j 分别指向数组的两端。
2. 设置一个循环，在每轮中使用 i（j）分别寻找第一个比基准数大（小）的元素，然后交换这两个元素。
3. 循环执行步骤 `2.` ，直到 i 和 j 相遇时停止，最后将基准数交换至两个子数组的分界线。

哨兵划分完成后，原数组被划分成三部分：左子数组、基准数、右子数组，且满足“左子数组任意元素 <= 基准数 <= 右子数组任意元素”。因此，我们接下来只需对这两个子数组进行排序。

```cpp
// 快速排序 递归
void quickSort(std::vector<int> &nums, int low, int high) {
    // 就剩一个元素了
    if (low >= high)
        return;

    // 获取分区后基准的正确索引
    int pivotIndex = partition(nums, low, high);

    // 递归排序左右两半
    quickSort(nums, low, pivotIndex - 1);
    quickSort(nums, pivotIndex + 1, high);
}

// 分区函数：返回基准元素最终所在的索引
int partition(std::vector<int> &nums, int low, int high) {
    // 基准选择规则：左侧第一个
    int pivot = nums[low];
    int i = low, j = high;

    while (i < j) {
        // 注意：右指针先走！寻找第一个小于 pivot 的数
        while (i < j && nums[j] >= pivot) {
            j--;
        }
        nums[i] = nums[j]; // 将小数填到左边的坑里

        // 左指针走！寻找第一个大于 pivot 的数
        while (i < j && nums[i] <= pivot) {
            i++;
        }
        nums[j] = nums[i]; // 将大数填到右边的坑里
    }

    // 基准归位：此时 i == j，将基准填入最后的坑
    nums[i] = pivot;

    // 返回基准的最终位置
    return i;
}
```

### 6. 堆排序

堆排序（heap sort）是一种基于堆数据结构实现的高效排序算法。

1. 输入数组并建立小顶堆，此时最小元素位于堆顶。
2. 不断执行出堆操作，依次记录出堆元素，即可得到从小到大排序的序列。

以上方法虽然可行，但需要借助一个额外数组来保存弹出的元素，比较浪费空间。在实际中，我们通常使用一种更加优雅的实现方式:

1. 输入数组并建立大顶堆。完成后，最大元素位于堆顶。
2. 将堆顶元素（第一个元素）与堆底元素（最后一个元素）交换。完成交换后，堆的长度减 1 ，已排序元素数量加 1。
3. 从堆顶元素开始，从顶到底执行堆化操作（sift down）。完成堆化后，堆的性质得到修复。
4. 循环执行第 `2.` 步和第 `3.` 步。循环 `n - 1` 轮后，即可完成数组排序。

```cpp
// 核心调整函数：向下调整
// 作用：将 start 位置的元素“下沉”到 end 范围内的正确位置，维持大顶堆性质
void insertHeap(std::vector<int> &nums, int start, int end) {
    int parent = start;
    int child = 2 * parent + 1; // 左孩子索引

    // 优化：暂存父节点的值，用赋值代替交换，减少内存写入次数
    int temp = nums[parent];

    while (child <= end) {
        // 如果右孩子存在，且右孩子大于左孩子，则选择右孩子
        if (child + 1 <= end && nums[child + 1] > nums[child]) {
            child++;
        }

        // 如果父节点已经大于等于最大子节点，说明满足堆性质，直接退出
        if (temp >= nums[child]) {
            break;
        }

        // 否则，将较大的子节点上移
        nums[parent] = nums[child];
        parent = child;
        child = 2 * parent + 1; // 继续向下找
    }
    // 将最初的父节点值放到最终的正确位置
    nums[parent] = temp;
}

// 建堆函数
// 作用：将无序数组原地构建为大顶堆
void buildHeap(std::vector<int> &nums) {
    int n = nums.size();
    if (n <= 1)
        return;

    // 从最后一个非叶子节点开始，逆序向上依次进行向下调整
    // 最后一个非叶子节点的索引是 n/2 - 1

    // 二叉树公式：
    // 求父：(n-1)/2
    // 求左子：2n+1
    // 求右子：2n+2
    for (int i = n / 2 - 1; i >= 0; --i) {
        insertHeap(nums, i, n - 1);
    }
}

// 堆排序
void heapSort(std::vector<int> &nums) {
    if (nums.empty())
        return;

    // 第一步：建大顶堆
    buildHeap(nums);

    int n = nums.size();
    // 第二步：依次将堆顶最大值交换到末尾，并重新调整堆
    for (int i = n - 1; i > 0; --i) {
        // 将堆顶（当前最大值）与当前堆的最后一个元素交换
        std::swap(nums[0], nums[i]);

        // 交换后，堆顶被破坏，对新的堆顶进行向下调整
        // 注意：此时堆的有效范围缩小了，end 变为 i - 1
        insertHeap(nums, 0, i - 1);
    }
}
```

### 7. 基数排序

计数排序适用于数据量较大但数据范围较小的情况。假设我们需要对个学号进行排序，而学号是一个位数字，这意味着数据范围非常大，使用计数排序需要分配大量内存空间，而基数排序可以避免这种情况。
基数排序（radix sort）的核心思想与计数排序一致，也通过统计个数来实现排序。在此基础上，基数排序利用数字各位之间的递进关系，依次对每一位进行排序，从而得到最终的排序结果。

## 排序特性

唯三稳定的排序:

- 插入排序
- 归并排序
- 基数排序

分治排序:

- 归并排序
- 快速排序

效率:

- 基于比较的排序 时间下界为 Ω(nlgn)
